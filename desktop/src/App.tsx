import { useCallback, useEffect, useState } from "react";
import { checkApiHealth, getApiBaseUrl, getAppEnvironment } from "./lib/api";
import "./App.css";

type LoadState = "idle" | "loading" | "ok" | "error";

function App() {
  const environment = getAppEnvironment();
  const apiBaseUrl = getApiBaseUrl();
  const [state, setState] = useState<LoadState>("idle");
  const [message, setMessage] = useState("Checking the SyncBox API...");

  const refreshHealth = useCallback(async () => {
    setState("loading");
    const result = await checkApiHealth();
    if (result.status === "ok") {
      setState("ok");
      setMessage(result.data.message);
      return;
    }

    setState("error");
    setMessage(result.message);
  }, []);

  useEffect(() => {
    void refreshHealth();
  }, [refreshHealth]);

  return (
    <main className="shell">
      <section className="card">
        <p className="eyebrow">SyncBox</p>
        <h1>Hello SyncBox</h1>
        <p className="lede">
          Desktop client foundation. The synchronization engine will land after
          this CI/CD path is green.
        </p>

        <dl className="meta">
          <div>
            <dt>Environment</dt>
            <dd>{environment}</dd>
          </div>
          <div>
            <dt>API</dt>
            <dd>{apiBaseUrl || "not configured"}</dd>
          </div>
        </dl>

        <div className={`status status-${state}`}>
          <span className="status-dot" />
          <div>
            <strong>
              {state === "ok"
                ? "API online"
                : state === "error"
                  ? "API unreachable"
                  : "Checking API"}
            </strong>
            <p>{message}</p>
          </div>
        </div>

        <button type="button" onClick={() => void refreshHealth()} disabled={state === "loading"}>
          Recheck health
        </button>
      </section>
    </main>
  );
}

export default App;
