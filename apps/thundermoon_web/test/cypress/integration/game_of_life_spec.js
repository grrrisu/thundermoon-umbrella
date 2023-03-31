/* global cy */

describe("game of life page", function () {
  beforeEach(function () {
    cy.request("PATCH", "/api/game_of_life/reset");
  });

  afterEach(function () {
    cy.logout();
  });

  describe("as a member without a grid", function () {
    beforeEach(function () {
      cy.login(123);
      cy.visit("/game_of_life");
    });

    it("I see no simulation available", function () {
      cy.get("p").contains("no simulation available");
    });
  });

  describe("as a member with a grid", function () {
    beforeEach(function () {
      cy.request({
        method: "POST",
        url: "/api/game_of_life/create",
        form: true,
        body: {
          size: "5",
        },
      }).then((_resp) => {
        cy.login(123);
        cy.visit("/game_of_life");
        cy.get(".phx-connected");
      });
    });

    it("I see a grid and can run it", function () {
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get("#start-button").contains("start").click();
      cy.get("#stop-button").contains("stop").click();
    });

    it("I can recreate it", function () {
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get("#start-button").contains("start").click();
      cy.get("#reset-button").contains("recreate").click();
      cy.get("#start-button").contains("start").click();
      cy.get("#stop-button").contains("stop").click();
    });

    it("I can clear it", function () {
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get("#clear-button").contains("clear").click();
      cy.get("#grid")
        .children(".cell:not(.game-of-life-active)")
        .should("have.length", 25);
    });

    it("I can change the value of a cell", function () {
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get("#clear-button").contains("clear").click();

      cy.get("#grid")
        .children(".cell")
        .first()
        .should("not.have.class", "game-of-life-active");

      cy.get("#grid").children(".cell").first().click({ force: true });

      cy.get("#grid")
        .children(".cell")
        .first()
        .should("have.class", "game-of-life-active");
    });
  });

  describe("as an admin", function () {
    beforeEach(function () {
      cy.login(456);
      cy.visit("/game_of_life");
      cy.get(".phx-connected");
    });

    it("create a grid an run it", function () {
      cy.get("h3").contains("Create a new Grid");
      cy.get("input#form_data_size").type("5");
      cy.get("form").submit();
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get("#start-button").contains("start").click();
      cy.get("#stop-button").contains("stop").click();
    });

    it("create a grid and recreate it", function () {
      cy.get("h3").contains("Create a new Grid");
      cy.get("input#form_data_size").type("5");
      cy.get("form").submit();
      cy.get("#start-button").contains("start").click();
      cy.get("#recreate-button").contains("recreate").click();
      cy.get("#start-button").contains("start").click();
      cy.get("#stop-button").contains("stop").click();
    });

    it("reset a grid and run it", function () {
      cy.get("h3").contains("Create a new Grid");
      cy.get("input#form_data_size").type("5");
      cy.get("form").submit();
      cy.get("#grid").children(".cell").should("have.length", 25);
      cy.get("#reset-button").contains("reset").click();
      cy.get("h3").contains("Create a new Grid");
      cy.get("input#form_data_size").type("4");
      cy.get("form").submit();
      cy.get("#grid").children(".cell").should("have.length", 16);
      cy.get("#start-button").contains("start").click();
      cy.get("#stop-button").contains("stop").click();
    });
  });
});
