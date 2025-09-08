import React from "react";
import { Link } from "react-router-dom";
import Logo from "./components/Logo";

export default function App() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
      <div className="text-center space-y-4">
        <Logo />
        <h1 className="text-2xl font-semibold">Welcome to Orga</h1>
        <p className="text-gray-600">This is a placeholder home. Please login.</p>
        <Link className="text-blue-600 underline" to="/login">Go to Login</Link>
      </div>
    </div>
  );
}
