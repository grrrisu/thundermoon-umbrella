/* global cy */

describe("root page", function () {
  beforeEach(function () {
    cy.login("/");
  });

  it("should see the title", function () {
    cy.contains("Thundermoon");
  });

  it("should show preview images", function () {
    cy.get('img[alt="chat"]').should("be.visible");
    cy.get('img[alt="counter"]').should("not.be.visible");
    cy.get("a").contains("counter").click();
    cy.get('img[alt="chat"]').should("not.be.visible");
    cy.get('img[alt="counter"]').should("be.visible");
  });
});

describe("dashboard page", function () {
  beforeEach(function () {
    cy.login(123);
  });

  afterEach(function () {
    cy.logout();
  });

  it("should see the title", function () {
    cy.visit("/dashboard");
    cy.contains("Welcome crumb");
  });
});
