/* global cy */

describe("counter page", function() {

  beforeEach(function() {
    cy.visit("/auth/integration?external_user_id=456");
    cy.visit("/counter");
    cy.contains("reset").click();
  });

  afterEach(function() {
    cy.contains("Logout").click();
  });

  it("inc and dec all digits", function() {
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

  it("inc next digit", function() {
    cy.get("#digit-10").should("have.text", "0");
    cy.get("#digit-100").should("have.text", "0");

    Array(...Array(9)).map((_n,_i) => {
      cy.get("#digit-10-inc").click();
    });
    cy.get("#digit-10").should("have.text", "9");

    cy.get("#digit-10-inc").click();
    cy.get("#digit-10").should("have.text", "0");
    cy.get("#digit-100").should("have.text", "1");
  });

  it("dec same digit should reset counter", function() {
    cy.get("#digit-1-inc").click();
    cy.get("#digit-1").should("have.text", "1");
    cy.get("#digit-10-inc").click();
    cy.get("#digit-10").should("have.text", "1");

    cy.get("#digit-10-dec").click();
    cy.get("#digit-10-dec").click();

    cy.get("#digit-1").should("have.text", "0");
    cy.get("#digit-10").should("have.text", "0");
    cy.get("#digit-100").should("have.text", "0");
  });

  it("dec next digit", function() {
    cy.get("#digit-100-inc").click();
    cy.get("#digit-100").should("have.text", "1");

    cy.get("#digit-1-dec").click();

    cy.get("#digit-1").should("have.text", "9");
    cy.get("#digit-10").should("have.text", "9");
    cy.get("#digit-100").should("have.text", "0");
  });

  it("reset counter", function() {
    cy.get("#digit-1-inc").click();
    cy.get("#digit-1").should("have.text", "1");
    cy.get("#digit-10-inc").click();
    cy.get("#digit-10").should("have.text", "1");
    cy.get("#digit-100-inc").click();
    cy.get("#digit-100").should("have.text", "1");

    cy.contains("reset").click();

    cy.get("#digit-1").should("have.text", "0");
    cy.get("#digit-10").should("have.text", "0");
    cy.get("#digit-100").should("have.text", "0");
  });

  it("start counter sim", function() {
    cy.get("#digit-1").should("have.text", "0");
    cy.contains("start").click();
    cy.get("#digit-1").should("have.text", "1");
    cy.contains("stop").click();
  });
});
