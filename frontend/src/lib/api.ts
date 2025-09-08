export type LoginPayload = { email: string; password: string };

const API_URL = (import.meta as { env?: { VITE_API_URL?: string } })?.env?.VITE_API_URL || "http://localhost:8000";

export async function login(payload: LoginPayload): Promise<{ token: string }> {
  const res = await fetch(`${API_URL}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    const msg = await res.text().catch(() => "Login failed");
    throw new Error(msg || `HTTP ${res.status}`);
  }
  return res.json();
}
