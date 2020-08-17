/* global cy */

describe("lotka volterra page", function() {

  afterEach(function() {
    cy.logout();
  });

  describe("as a member", function() {

    beforeEach(function() {
      cy.login(123);
      cy.visit("/lotka-volterra/new");
      cy.get("h1").contains("Lotka Volterra");
    });

    it("I can start a simulation", function() {
      cy.get("input#vegetation_capacity").clear().type("5000");
      cy.get("input#vegetation_birth_rate").clear().type("0.5");
      cy.get("input#vegetation_death_rate").clear().type("0.1");
      cy.get("input#vegetation_size").clear().type("150");
      cy.get("form").submit();

      cy.get("#chart");
      cy.contains("start").click();
      cy.contains("stop").click();
    });

    it("I can recreate a simulation", function(){
      cy.get("input#vegetation_capacity").clear().type("5000");
      cy.get("form").submit();
      cy.get("#chart");
      cy.contains("recreate").click();
      cy.get("input#vegetation_size").clear().type("150");
      cy.get("form").submit();
      cy.get("#chart");
    })

  });

});
