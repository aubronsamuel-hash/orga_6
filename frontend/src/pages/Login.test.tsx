import { render, screen, fireEvent } from "@testing-library/react";
import "@testing-library/jest-dom";
import Login from "./Login";
import { vi } from "vitest";

vi.mock("@/lib/api", () => ({ login: vi.fn(async () => ({ token: "t" })) }));

it("shows validation error on empty fields", async () => {
  render(<Login />);
  fireEvent.submit(screen.getByRole("button", { name: /se connecter/i }));
  expect(await screen.findByRole("alert")).toHaveTextContent(/invalide/i);
});
