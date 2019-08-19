/* global cy */

describe("root page", function() {
  it("should see the title", function() {
    cy.visit("/");
    cy.contains("Thundermoon");
  })
});

describe("dashboard page", function() {

  beforeEach(function() {
    cy.visit("/auth/integration?external_user_id=123");
  });

  afterEach(function() {
    cy.contains("Logout").click();
  });

  it("should see the title", function() {
    cy.visit("/dashboard");
    cy.contains("Welcome crumb");
  })
});
