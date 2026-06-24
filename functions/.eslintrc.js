module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
    "/generated/**/*", // Ignore generated files.
    "/scripts/**/*", // Ignore local scripts not covered by tsconfig.
  ],
  plugins: ["@typescript-eslint", "import"],
  rules: {
    quotes: ["error", "double"],
    "import/no-unresolved": 0,
    indent: 0,
    // Disable brace spacing to accommodate mixed styles in current codebase
    "object-curly-spacing": 0,
    // Avoid noisy operator linebreak issues from Google config
    "operator-linebreak": 0,
    "require-jsdoc": 0,
    "quote-props": 0,
    "max-len": 0,
  },
};
