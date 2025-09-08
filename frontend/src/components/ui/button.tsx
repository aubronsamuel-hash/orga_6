import React from "react";
import { cn } from "./utils";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & { variant?: "default" | "outline" };

export function Button({ className, variant = "default", ...props }: Props) {
  const base = "inline-flex items-center justify-center rounded-md text-sm font-medium h-10 px-4 py-2 transition disabled:opacity-50 disabled:pointer-events-none";
  const styles = variant === "outline"
    ? "border border-gray-300 bg-white text-gray-900 hover:bg-gray-50"
    : "bg-gray-900 text-white hover:bg-black";
  return <button className={cn(base, styles, className)} {...props} />;
}
