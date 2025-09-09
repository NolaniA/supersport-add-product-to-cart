# variable
BASE_URL = "https://www.supersports.co.th"
PATH_CART = "/cart"
LIMIT_ADD_ITEM_PER_BRAND = 1
LIMIT_TOP_BRAND = 2   # 0 : get all top brand 


# dictionary
CART = {}
ITEM_PRODUCT = {}

# list
SORTINGS_MENU = []
PENDING_ADD_TO_CART = []
TOP_BRAND_PATH = []


# api
API = {
    "cart_detail" : f"{BASE_URL}/cart.js",
    "add_cart" : f"{BASE_URL}/cart/add",
    "clear_cart" : f"{BASE_URL}/cart/clear.js",
    "product_detail" : f"{BASE_URL}"
}



# selector
SELECTOR = {
    "text_view_all_top_brand" : "div#pb__collection__list--bc44d161-02c5-49 a.pb__view__all",
    "title_top_brands" : 'text="TOP BRANDS"',
    "brands_collection" : "div.pb__collection__all__content div.pb__collection__card",
    "text_clear_cart" : "div.form-header cart-remove-all.clear-cart",
    "button_add_to_cart" : "button.product-form__submit",
    "section_category" : "div.pb__collection__list.pb__section",
    "category" : "div.pb__collection__list.pb__section div.pb__collection__card",
    "sorting_option" : "ul.boost-sd__sorting-list",
    "loading" : "div#boost-sd-loading-icon-filter.boost-sd__g-hide",
    "img_product_list" : "div.boost-sd__product-item-grid-view-layout-image",
    "img_cart_list" : "td.cart-item__media img",
    "brand_cart_list" : "td.information p.product-vendor",
    "link_cart_list" : "td.information div > a",
    "desc_cart_list" : "td.information div > a",
    "option_cart_list" : "td.information div.product-option",
    "old_price_cart_list" : "td.price-desktop span.cart-item__old-price",
    "final_price_cart_list" : "td.price-desktop strong.cart-item__final-price",
    "quantity_cart_list" : "td.cart-item__quantity input.quantity__input",
    "price_end_cart_list" : "td.cart-item__totals .price--end",
    "total_bill_cart" : "span.origin-total-price",
    "headmenu_view_all_top_brand" : "a#HeaderMenu-brands"

}
