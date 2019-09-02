/* global cy */

describe("counter page", function() {

  beforeEach(function() {
    cy.visit("/auth/integration?external_user_id=456");
  });

  afterEach(function() {
    //cy.contains("Clear all messages").click();
    cy.contains("Logout").click();
  });

  it("inc and dec all digits", function() {
    cy.visit("/counter");
    cy.get("#digit-1").should("have.text", "0");
    cy.get("#digit-1-inc").click();
    cy.get("#digit-1").should("have.text", "1");
    cy.get("#digit-1-dec").click();
    cy.get("#digit-1").should("have.text", "0");

    cy.get("#digit-10").should("have.text", "0");
    cy.get("#digit-10-inc").click();
    cy.get("#digit-10").should("have.text", "1");
    cy.get("#digit-10-dec").click();
    cy.get("#digit-10").should("have.text", "0");

    cy.get("#digit-100").should("have.text", "0");
    cy.get("#digit-100-inc").click();
    cy.get("#digit-100").should("have.text", "1");
    cy.get("#digit-100-dec").click();
    cy.get("#digit-100").should("have.text", "0");
  });

  it("inc to next digit", function () {
    cy.visit("/counter");
    cy.get("#digit-10").should("have.text", "0");
    cy.get("#digit-100").should("have.text", "0");

    Array(...Array(9)).map((_n,_i) => {
      cy.get("#digit-10-inc").click();
    });
    cy.get("#digit-10").should("have.text", "9");

    cy.get("#digit-10-inc").click();
    cy.get("#digit-10").should("have.text", "0");
    cy.get("#digit-100").should("have.text", "1");

    cy.get("#digit-100-dec").click();
    cy.get("#digit-100").should("have.text", "0");
  });

  it("dec to next digit should reset counter", function () {
    cy.visit("/counter");
    cy.get("#digit-1-inc").click();
    cy.get("#digit-1").should("have.text", "1");
    cy.get("#digit-10-inc").click();
    cy.get("#digit-10").should("have.text", "1");
    cy.get("#digit-100-inc").click();
    cy.get("#digit-100").should("have.text", "1");

    cy.get("#digit-10-dec").click();
    cy.get("#digit-10-dec").click();

    cy.get("#digit-1").should("have.text", "0");
    cy.get("#digit-10").should("have.text", "0");
    cy.get("#digit-100").should("have.text", "0");
  });
});