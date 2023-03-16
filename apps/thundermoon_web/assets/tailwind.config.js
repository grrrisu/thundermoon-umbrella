const plugin = require("tailwindcss/plugin");

module.exports = {
  content: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/*.html.heex",
    "../**/views/**/*.ex",
    "../**/components/**/*.ex",
    "../**/live/**/*.ex",
    "./css/**/*.css",
    "./js/**/*.js",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),
  ],
};
