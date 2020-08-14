// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//

/* global cy */
Cypress.Commands.add("login", (external_user_id) => {
  cy
    .request({
      method: "POST",
      url: "/api/login/",
      form: true,
      body: {
        external_user_id: external_user_id
      }
    })
    .then((_resp) => {
      cy.visit("/dashboard");
    });
});

Cypress.Commands.add("logout", () => {
  cy
    .request({
      method: "DELETE",
      url: "/api/logout/"
    })
    .then((_resp) => {
      cy.visit("/");
    });
});


//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })
