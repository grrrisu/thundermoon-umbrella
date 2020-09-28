/* global cy */

describe("game of life page", function() {

  beforeEach(function() {
    cy.request("PATCH", "/api/game_of_life/restart");
  });

  afterEach(function() {
    cy.logout();
  });

  describe("as a member without a grid", function() {

    beforeEach(function() {
      cy.login(123);
      cy.visit("/game_of_life");
    });

    it("I see no simulation available", function() {
      cy.get("p").contains("no simulation available");
    });

  });

  describe("as a member with a grid", function() {

    beforeEach(function() {
      cy
        .request({
          method: "POST",
          url: "/api/game_of_life/create",
          form: true,
          body: {
            size: "5"
          }
        })
        .then((_resp) => {
          cy.login(123);
          cy.visit("/game_of_life");
        });
    });

    it("I see a grid and can run it", function() {
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get(".button").contains("start").click();
      cy.get(".button").contains("stop").click();
    });

    it("I can reset it", function() {
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get(".button").contains("start").click();
      cy.get(".button").contains("reset").click();
      cy.get(".button").contains("start").click();
      cy.get(".button").contains("stop").click();
    });

    it("I can clear it", function() {
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get(".button").contains("clear").click();
      cy.get("#grid").children(".cell:not(.active)").should("have.length", 25);
    });

    it("I can change the value of a cell", function() {
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get(".button").contains("clear").click();

      cy.get("#grid")
      .children(".cell")
      .first()
      .should("not.have.class", "alive")
      .click()
      .should("have.class", "alive");
    });

  });

  describe("as an admin", function() {

    beforeEach(function() {
      cy.login(456);
      cy.visit("/game_of_life");
    });

    it("create a grid an run it", function() {
      cy.get("h3").contains("Create a new Grid");
      cy.get("input#form_data_size").type("5");
      cy.get("form").submit();
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get(".button").contains("start").click();
      cy.get(".button").contains("stop").click();
    });

    it("create a grid and reset it", function() {
      cy.get("h3").contains("Create a new Grid");
      cy.get("input#form_data_size").type("5");
      cy.get("form").submit();
      cy.get(".button").contains("start").click();
      cy.get(".button").contains("reset").click();
      cy.get(".button").contains("start").click();
      cy.get(".button").contains("stop").click();
    });

    it("recreate a grid and run it", function() {
      cy.get("h3").contains("Create a new Grid");
      cy.get("input#form_data_size").type("5");
      cy.get("form").submit();
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get(".button").contains("recreate").click();
      cy.get("h3").contains("Create a new Grid");
      cy.get("input#form_data_size").type("4");
      cy.get("form").submit();
      cy.get("#grid").children(".cell").should("have.length", 16);
      cy.get(".button").contains("start").click();
      cy.get(".button").contains("stop").click();
    });

  });

});

