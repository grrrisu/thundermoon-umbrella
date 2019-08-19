/* global cy */

describe("chat page", function() {

  beforeEach(function() {
    cy.visit("/auth/integration?external_user_id=456");
  });

  afterEach(function() {
    cy.contains("Clear all messages").click();
    cy.contains("Logout").click();
  });

  it("send a chat message", function() {
    cy.visit("/chat");
    cy.get("input#message_text").type("this freaks me out!");
    cy.get("form").submit();
    cy.get("#messages").contains("gilbert_shelton");
    cy.get("#messages").contains("this freaks me out!");
  });
});

