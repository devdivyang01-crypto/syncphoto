export type HealthResponse = {
  success: boolean;
  message: string;
};

export type HealthCheckResult =
  | { status: "ok"; data: HealthResponse }
  | { status: "error"; message: string };

export function getAppEnvironment(): string {
  return import.meta.env.VITE_APP_ENV?.trim() || "development";
}

export function getApiBaseUrl(): string {
  const configured = import.meta.env.VITE_API_BASE_URL?.trim();
  if (configured) {
    return configured.replace(/\/$/, "");
  }

  if (import.meta.env.DEV) {
    return "http://127.0.0.1:8080";
  }

  return "";
}

export function healthEndpointUrl(baseUrl: string = getApiBaseUrl()): string {
  if (!baseUrl) {
    throw new Error("API_BASE_URL is not configured for this environment.");
  }

  return `${baseUrl.replace(/\/$/, "")}/api/v1/health`;
}

export function parseHealthResponse(value: unknown): HealthResponse {
  if (
    typeof value !== "object" ||
    value === null ||
    !("success" in value) ||
    !("message" in value)
  ) {
    throw new Error("Unexpected health response.");
  }

  const payload = value as { success: unknown; message: unknown };
  if (typeof payload.success !== "boolean" || typeof payload.message !== "string") {
    throw new Error("Unexpected health response.");
  }

  return { success: payload.success, message: payload.message };
}

export async function checkApiHealth(
  fetchImpl: typeof fetch = fetch,
): Promise<HealthCheckResult> {
  try {
    const response = await fetchImpl(healthEndpointUrl(), {
      method: "GET",
      headers: { Accept: "application/json" },
    });

    if (!response.ok) {
      return {
        status: "error",
        message: `Health check failed with HTTP ${response.status}.`,
      };
    }

    const data = parseHealthResponse(await response.json());
    if (!data.success) {
      return { status: "error", message: data.message };
    }

    return { status: "ok", data };
  } catch (error) {
    return {
      status: "error",
      message: error instanceof Error ? error.message : "Health check failed.",
    };
  }
}
