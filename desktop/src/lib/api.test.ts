import { describe, expect, it } from "vitest";
import {
  healthEndpointUrl,
  parseHealthResponse,
} from "./api";

describe("healthEndpointUrl", () => {
  it("joins the health path without duplicating slashes", () => {
    expect(healthEndpointUrl("http://127.0.0.1:8080/")).toBe(
      "http://127.0.0.1:8080/api/v1/health",
    );
  });

  it("rejects an empty base URL", () => {
    expect(() => healthEndpointUrl("")).toThrow(/API_BASE_URL/);
  });
});

describe("parseHealthResponse", () => {
  it("accepts the SyncBox health payload", () => {
    expect(
      parseHealthResponse({
        success: true,
        message: "SyncBox API is running",
      }),
    ).toEqual({
      success: true,
      message: "SyncBox API is running",
    });
  });

  it("rejects malformed payloads", () => {
    expect(() => parseHealthResponse({ ok: true })).toThrow(
      /Unexpected health response/,
    );
  });
});
