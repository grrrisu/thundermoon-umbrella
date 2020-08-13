/* global cy */

describe("lotka volterra page", function() {

  afterEach(function() {
    cy.logout();
  });

  describe("as a member", function() {

    beforeEach(function() {
      cy.login(123);
      cy.visit("/lotka-volterra");
    });

    it("I can start a simulation", function() {
      cy.get("h1").contains("Lotka Volterra");
      cy.get("#chart");
      cy.contains("create").click();
      cy.contains("start").click();
      cy.contains("stop").click();
    });

  });

});
