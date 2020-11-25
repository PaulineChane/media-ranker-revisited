require "application_system_test_case"

describe "Products", :system do
  let(:product) { products(:one) }

  it "visiting the index" do
    visit products_url
    assert_selector "h1", text: "Products"
  end

  it "creating a Product" do
    visit products_url
    click_on "New Product"

    click_on "Create Product"

    assert_text "Product was successfully created"
    click_on "Back"
  end

  it "updating a Product" do
    visit products_url
    click_on "Edit", match: :first

    click_on "Update Product"

    assert_text "Product was successfully updated"
    click_on "Back"
  end

  it "destroying a Product" do
    visit products_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Product was successfully destroyed"
  end
end
