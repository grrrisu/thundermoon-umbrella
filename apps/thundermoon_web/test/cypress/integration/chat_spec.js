/* global cy */

describe("chat page", function () {
  beforeEach(function () {
    cy.login(456);
  });

  afterEach(function () {
    cy.contains("Clear all messages").click();
    cy.logout();
  });

  it("send a chat message", function () {
    cy.visit("/chat");
    cy.get(".phx-connected");
    cy.get("input#message_text").type("this freaks me out!");
    cy.get("form").submit();
    cy.get("#messages").contains("gilbert_shelton");
    cy.get("#messages").contains("this freaks me out!");
  });
});
