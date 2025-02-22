/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class WebsiteAccessTests: BaseTestCase {
    // Smoketest
    func testVisitWebsite() {
        // Check initial page
        checkForHomeScreen()

        // Enter 'mozilla' on the search field
        let searchOrEnterAddressTextField = app.textFields["URLBar.urlText"]
        XCTAssertTrue(searchOrEnterAddressTextField.exists)
        XCTAssertTrue(searchOrEnterAddressTextField.isEnabled)

        // Check the text autocompletes to mozilla.org/, and also look for 'Search for mozilla' button below
        let label = app.textFields["URLBar.urlText"]
        searchOrEnterAddressTextField.tap()
        searchOrEnterAddressTextField.typeText("mozilla")
        waitForValueMatch(element: label, value: "mozilla.org/")
        waitforExistence(element: app.buttons["Search for mozilla"])

        // BB CI seems to hang intermittently where http to https redirection occurs.
        // Providing straight URL to avoid the error - and use internal website
        app.buttons["icon clear"].tap()
        loadWebPage("https://www.example.com")
        waitForValueContains(element: label, value: "www.example.com")

        // Erase the history
        app.buttons["URLBar.deleteButton"].tap()

        // Check it is on the initial page
        checkForHomeScreen()
    }

    func testDisableAutocomplete() {
        // Disable Autocomplete
        app.buttons["Settings"].tap()
        app.tables.cells["SettingsViewController.autocompleteCell"].tap()
        waitforExistence(element: app.tables.switches["toggleAutocompleteSwitch"])
        var toggle = app.tables.switches["toggleAutocompleteSwitch"]
        toggle.tap()

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let searchOrEnterAddressTextField = app.textFields["URLBar.urlText"]

        searchOrEnterAddressTextField.tap()
        searchOrEnterAddressTextField.typeText("mozilla")
        waitforExistence(element: app.buttons["OverlayView.searchButton"])
        let searchForButton = app.buttons["OverlayView.searchButton"]
        XCTAssertNotEqual(searchForButton.label, "Search for mozilla.org/")
        waitForValueMatch(element: searchOrEnterAddressTextField, value: "mozilla")
        app.buttons["URLBar.cancelButton"].tap()

        // Enable autocomplete
        app.buttons["Settings"].tap()
        app.tables.cells["SettingsViewController.autocompleteCell"].tap()
        toggle = app.tables.switches["toggleAutocompleteSwitch"]
        toggle.tap()

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        searchOrEnterAddressTextField.tap()
        searchOrEnterAddressTextField.typeText("mozilla")
        XCTAssertNotEqual(searchForButton.label, "Search for mozilla.org/")
        waitForValueMatch(element: searchOrEnterAddressTextField, value: "mozilla.org/")
        app.buttons["URLBar.cancelButton"].tap()
    }

    func testAutocompleteCustomDomain() {
        // Add Custom Domain
        app.buttons["Settings"].tap()
        app.tables.cells["SettingsViewController.autocompleteCell"].tap()
        app.tables.cells["customURLS"].tap()
        app.tables.cells["addCustomDomainCell"].tap()

        let urlInput = app.textFields["urlInput"]
        urlInput.typeText("getfirefox.com")
        app.navigationBars.buttons["saveButton"].tap()

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Test auto completing the domain
        let searchOrEnterAddressTextField = app.textFields["URLBar.urlText"]
        searchOrEnterAddressTextField.tap()
        searchOrEnterAddressTextField.typeText("getfire")
        waitforExistence(element: app.buttons["Search for getfire"])
        waitForValueMatch(element: searchOrEnterAddressTextField, value: "getfirefox.com/")

        // Remove the custom domain
        app.buttons["URLBar.cancelButton"].tap()
        app.buttons["Settings"].tap()
        app.tables.cells["SettingsViewController.autocompleteCell"].tap()
        app.tables.cells["customURLS"].tap()
        app.navigationBars.buttons["editButton"].tap()
        app.tables.cells["getfirefox.com"].buttons["Delete getfirefox.com"].tap()
        app.tables.cells["getfirefox.com"].buttons["Delete"].tap()

        // Finish Editing
        app.navigationBars.buttons["editButton"].tap()
    }
}
