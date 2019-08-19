/* global cy */

describe("chat page", function() {

  beforeEach(function() {
    cy.visit("/auth/integration?external_user_id=123");
  });

  afterEach(function() {
    // clear all messages
    cy.contains("Logout").click();
  });

  it("send a chat message", function() {
    cy.visit("/chat");
    cy.get("input#message_text").type("hello everyone!");
    cy.get("form").submit();
    cy.get("#messages").contains("crumb");
    cy.get("#messages").contains("hello everyone!");
  });
});

