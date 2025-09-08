module.exports = {
  root: true,
  env: { browser: true, es2023: true },
  parser: "@typescript-eslint/parser",
  parserOptions: { ecmaVersion: "latest", sourceType: "module" },
  plugins: ["react-refresh", "@typescript-eslint"],
  extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  settings: {},
  rules: {
    "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
  },
};
