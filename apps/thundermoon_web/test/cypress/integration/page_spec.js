describe('root page', function() {
  it('should see the title', function() {
    cy.visit("/");
    cy.contains('Thundermoon');
  })
});

describe('dashboard page', function() {

  beforeEach(function() {
    cy.visit("/auth/integration?external_user_id=123");
  });

  afterEach(function() {
    cy.contains('Logout').click();
  })

  it('should see the title', function() {
    cy.visit("/dashboard");
    cy.contains('Welcome crumb');
  })
});

describe('chat page', function() {

  beforeEach(function() {
    cy.visit("/auth/integration?external_user_id=123");
  });

  afterEach(function() {
    // clear all messages
    cy.contains('Logout').click();
  })

  it('send a chat message', function() {
    cy.visit("/chat");
    cy.get("input#message_text").type("hello everyone!");
    cy.get("form").submit();
    cy.get("#messages").contains("crumb");
    cy.get("#messages").contains("hello everyone!");
  })
});

