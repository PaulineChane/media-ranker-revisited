require "test_helper"

describe ProductsController do
  let(:product) { products(:one) }

  it "should get index" do
    get products_url
    must_respond_with :success
  end

  it "should get new" do
    get new_product_url
    must_respond_with :success
  end

  it "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: {  } }
    end

    must_redirect_to product_url(Product.last)
  end

  it "should show product" do
    get product_url(@product)
    must_respond_with :success
  end

  it "should get edit" do
    get edit_product_url(@product)
    must_respond_with :success
  end

  it "should update product" do
    patch product_url(@product), params: { product: {  } }
    must_redirect_to product_url(product)
  end

  it "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    must_redirect_to products_url
  end
end
