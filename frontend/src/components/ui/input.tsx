import React from "react";
import { cn } from "./utils";

type Props = React.InputHTMLAttributes<HTMLInputElement>;

export const Input = React.forwardRef<HTMLInputElement, Props>(function Input({ className, ...props }, ref) {
  return (
    <input
      ref={ref}
      className={cn("flex h-10 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-900", className)}
      {...props}
    />
  );
});
