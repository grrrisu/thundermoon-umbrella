module.exports = {
  mode: "jit",
  purge: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/*.html.heex",
    "../**/views/**/*.ex",
    "../**/live/**/*.ex",
    "./css/**/*.css",
    "./js/**/*.js",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
