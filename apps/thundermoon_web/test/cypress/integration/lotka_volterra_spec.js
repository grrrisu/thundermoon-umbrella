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

    it("I can add a herbivore to the simulation", function(){
      cy.get("h3").contains("Vegetation");
      cy.get("a").contains("Add Herbivore").click();
      cy.get("h3").contains("Herbivore");
      cy.get("input#herbivore_birth_rate").clear().type("0.5");
      cy.get("input#herbivore_death_rate").clear().type("0.1");
      cy.get("input#herbivore_needed_food").clear().type("2");
      cy.get("input#herbivore_starving_rate").clear().type("0.2");
      cy.get("input#herbivore_graze_rate").clear().type("0.05");
      cy.get("input#herbivore_size").clear().type("20");
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
    });

  });

});
