/* global cy */

describe("root page", function() {
  it("should see the title", function() {
    cy.visit("/");
    cy.contains("Thundermoon");
  });
});

describe("dashboard page", function() {

  beforeEach(function() {
    cy.login(123);
  });

  afterEach(function() {
    cy.logout();
  });

  it("should see the title", function() {
    cy.visit("/dashboard");
    cy.contains("Welcome crumb");
  });
});
