*** Settings ***
# library
Library    Browser    
Library    Collections
Library    String

# variable
Variables    var_supersport.py

# setup
Suite Setup    Inital Browser
Test Setup    Remove All Items From Cart
Test Teardown    Remove All Items In Cart

*** Variables ***
${BROWSER}    chromium
${HEADLESS}    ${False}


*** Test Cases ***

Add Products To Cart
    View All Top Brands From Home Page
    Select Brands From Top Brands
    Sorting And Select Products 
    Add Product To Cart
    Validate Products In Cart


*** Keywords ***

# inital browser
Inital Browser
    [Documentation]    Open browser, create context and go to base url
    Set Browser Timeout    timeout=25s
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context    viewport={"width": 1400, "height": 700}
    New Page    url=${BASE_URL}    wait_until=domcontentloaded

    

Select Product From Category
    [Documentation]    Randomly pick a product category if section exists
    # check page has section option product
    ${product_category}    Run Keyword And Return Status    
        ...    Get Element Count    
        ...    ${SELECTOR['section_category']}    
        ...    >=    
        ...    assertion_expected=${1}

    # random pick category
    IF    ${product_category}
        @{products}    Get Elements    ${SELECTOR['category']}
        ${choice}    Evaluate    random.choice(@{products})
        Wait For Elements State    ${choice}
        Click    ${choice}
    END

Get Sorting Menu   
    [Documentation]     Collect all sorting option values from menu
    # get attribute option menu for first time
    Wait For Elements State    ${SELECTOR['sorting_option']}    attached

    @{list_temp}    Create List
    @{options}    Get Elements    ${SELECTOR['sorting_option']} li
    FOR    ${option}    IN    @{options}
        ${value}    Get Attribute    ${option}    data-value    
        Append To List    ${list_temp}    ${value}
    END
    Log    option_attribute:${list_temp}    console=${False}

    Set Global Variable    ${SORTINGS_MENU}    ${list_temp}

    RETURN    ${list_temp}

# random click sorting with javaScript (click from document, ignore dropdown, depend on website)
Random Selected Sorting
    [Documentation]    Randomly select a sorting option if not skipped
    [Arguments]    ${sort_list}=${SORTINGS_MENU}
    ${skip_sorting}    Evaluate    random.choice([${True}, ${False}])
    IF    ${skip_sorting}    
        RETURN
    END

    ${random_sorting}    Evaluate    random.choice(@{sort_list})
    Evaluate JavaScript    li[data-value="${random_sorting}"]    element => element.click()

    # wait sorting active
    Wait Until Keyword Succeeds    1m    2s    
        ...    Get Url    
        ...    contains    
        ...    ${random_sorting}


    # check page respone, reload page if product not found from sorting
    ${product_show}    Run Keyword And Return Status    
        ...    Get Element Count    
        ...    ${SELECTOR['img_product_list']}    
        ...    >=    ${1}

    IF    not ${product_show}
        ${current_url}    Get Url
        Go To    ${current_url}    wait_until=domcontentloaded
    END
    

    # wait page loading disable
    Wait Until Keyword Succeeds    1m    2s    
        ...    Get Element Count    
        ...    ${SELECTOR['loading']}   
        ...    >=    ${1}

Get Product Url
    [Documentation]    Collect product URLs and update pending list
    [Arguments]    ${loadmore}=${False}
    # loadmore
    Run Keyword If    ${loadmore}    Scroll To    vertical=bottom

    # get product elements
    @{products}    Get Elements    ${SELECTOR['img_product_list']} > a
    @{list_temp}    Create List
    FOR    ${product}    IN    @{products}
        ${link_product}    Get Attribute    ${product}    href
        Append To List    ${list_temp}    ${link_product}
    END    

    # pick random product and update pending list
    ${new_list_temp}    Run Keyword If    ${LIMIT_ADD_ITEM_PER_BRAND} > len(${list_temp})   
        ...    Set Variable      ${list_temp}    
    ...    ELSE      
        ...    Evaluate    random.sample(${list_temp}, ${LIMIT_ADD_ITEM_PER_BRAND})
    ${new_pending}    Combine Lists    ${PENDING_ADD_TO_CART}    ${new_list_temp}
    Set Global Variable    ${PENDING_ADD_TO_CART}    ${new_pending}

Remove All Items From Cart
    [Documentation]    Get cart detail and clear all items
    # get cart detail and clear cart
    ${response_cart_detail}    Wait For Response    ${API['cart_detail']}**

    # cart clear all
    IF    ${response_cart_detail['body']['item_count']} > ${0}
        Remove All Items In Cart
        # set defaut home page
        Go To    ${BASE_URL}    wait_until=domcontentloaded
    END
    
    Should Be Equal    ${response_cart_detail['body']['item_count']}    ${0}

View All Top Brands From Home Page
    [Documentation]    Click "View All Top Brands" link from home page and wait for page load
    # wait text link of page top brand and click text link
    Wait For Elements State    ${SELECTOR['text_view_all_top_brand']}     attached    
    # get href as expected of click
    ${page_url_top_brand}    Get Attribute    
        ...    ${SELECTOR['text_view_all_top_brand']}    
        ...    attribute=href

    Click    ${SELECTOR['text_view_all_top_brand']}
    
    # wait page top brand active
    Wait Until Keyword Succeeds    1m    2s
        ...    Get Url    
        ...    equal    
        ...    ${BASE_URL}${page_url_top_brand}

Select Brands From Top Brands
    [Documentation]    Get all top brand URLs and pick random limited brands

    # wait text "top brand"
    Wait For Elements State    ${SELECTOR['title_top_brands']}    attached
    @{top_brands}    Get Elements    ${SELECTOR['brands_collection']}
    
    # get url top brand
    @{list_brand_path}    Create List
    FOR    ${brand}    IN    @{top_brands}
        ${href_page_brand}    Get Attribute    
            ...    ${brand} >> div > a:nth-child(1)    
            ...    attribute=href
        Log   ${href_page_brand}    console=${False}
        Append To List    ${list_brand_path}    ${href_page_brand}
    END

    # random pick brand paths (limit by LIMIT_TOP_BRAND)
    ${total_brands}    Get Length    ${list_brand_path}
    ${list_brand_path}    Run Keyword If    ${LIMIT_TOP_BRAND} == ${0} or ${LIMIT_TOP_BRAND} > ${total_brands}    
        ...    Set Variable    ${list_brand_path}
    ...    ELSE
        ...    Evaluate    random.sample(${list_brand_path}, ${LIMIT_TOP_BRAND})
    
    Log    ${list_brand_path}    console=${False}

    Set Global Variable    ${TOP_BRAND_PATH}    ${list_brand_path}

Sorting And Select Products 
    [Documentation]    Go to top brand pages, sort products, and get product URLs
    [Arguments]    ${list_of_path_top_brand}=${TOP_BRAND_PATH}
    # sorting and get product url
    FOR    ${index}    ${path}    IN ENUMERATE    @{list_of_path_top_brand}
        Go To    ${BASE_URL}${path}    wait_until=domcontentloaded

        Select Product From Category    # excue if page dont show product

        Run Keyword If    ${index} == ${0}    Get Sorting Menu
        
        Random Selected Sorting

        Get Product Url
    END

Add Product To Cart
    [Documentation]    Go to product pages, get details, add to cart, and update ITEM_PRODUCT
    # add product to cart
    FOR    ${path}    IN    @{PENDING_ADD_TO_CART}
        # go to product page
        Go To    ${BASE_URL}${path}    wait_until=domcontentloaded

        # get product detail
        WHILE    ${True}
            ${respone_product_detail}    Wait For Response    ${API['product_detail']}${path}.js
            Run Keyword If    ${respone_product_detail['status']} == ${200}    
                ...    Exit For Loop
            ...    ELSE
                ...    Reload    waitUntil=domcontentloaded
            
        END
        
        
        Log    product_detail: ${respone_product_detail['body']}    console=${False}
        ${product_id}    Set Variable    ${respone_product_detail['body']['vendor']}-${respone_product_detail['body']['id']}
        Set To Dictionary   ${ITEM_PRODUCT}     
            ...    ${product_id}  
            ...    ${respone_product_detail['body']}

        # add to cart
        Click    ${SELECTOR['button_add_to_cart']}

        # wait add to cart success
        ${respone_add_success}    Wait For Response    ${API['add_cart']}
        Set To Dictionary   ${ITEM_PRODUCT['${product_id}']}     
            ...    detail_item    
            ...    ${respone_add_success['body']}
       
        Log    ${ITEM_PRODUCT}    console=${False}
    END

Remove All Items In Cart
    [Documentation]    Go to cart page and remove all items if any
    Go To    ${BASE_URL}${PATH_CART}    wait_until=domcontentloaded
    # wait text and clear all
    Wait For Elements State    ${SELECTOR['text_clear_cart']}    attached
    Click    ${SELECTOR['text_clear_cart']}
    # wait clear cart success
    ${respone_clear_success}    Wait For Response    ${API['clear_cart']}
    ${response_cart_detail}    Wait For Response    ${API['cart_detail']}**

Validate Products In Cart    
    [Documentation]    Validate that all products in the cart match the added products, including:
    ...                 - Image
    ...                 - Brand / Vendor
    ...                 - Product link
    ...                 - Title / Description
    ...                 - Variant / Option
    ...                 - Original price and final price
    ...                 - Quantity
    ...                 - Total price per product
    ...                 - Total bill

    Go To    ${BASE_URL}${PATH_CART}    wait_until=domcontentloaded
    
    ${product_ids}    Get Dictionary Keys    ${ITEM_PRODUCT}    sort_keys=${False}

    # wait product list show
    ${total_product}    Get Length    ${product_ids}
    Wait Until Keyword Succeeds    1m    3s    
        ...    Get Element Count    
        ...    div#main-cart-items tr    
        ...    >=    ${total_product}



    Reverse List    ${product_ids}    
    ${total_bill}    Evaluate    int(0)
    ${data_item_product}    Set Variable    ${ITEM_PRODUCT}
    FOR    ${index}    ${id}    IN ENUMERATE    @{product_ids}
        ${data_item}    Get From Dictionary    ${data_item_product}    ${id}
        ${detail_item}    Get From Dictionary    ${data_item}    detail_item

        # get data
        ${image}    Get From Dictionary    ${detail_item}    image
        ${match_path_src}    Get Regexp Matches    ${image}    [0-9][/](files[/].+)    1   
        ${src}    Set Variable    //www.supersports.co.th/cdn/shop/${match_path_src[0]}&width=110

        ${vendor}    Get From Dictionary    ${detail_item}   vendor
        ${vendor}    Replace String     ${vendor}    rev edition    replace_with=TEVA

        ${title}    Get From Dictionary    ${data_item}   title
        ${url}    Get From Dictionary    ${detail_item}   handle
        ${option}    Get From Dictionary   ${detail_item}    variant_title

        ${original_price}    Get From Dictionary    ${data_item}    compare_at_price
        ${old_price}    Evaluate    "{:,}".format(int(${original_price} / 100))

        ${current_price}    Get From Dictionary    ${data_item}    price     
        ${final_price}    Evaluate    "{:,}".format(int(${current_price} / 100))
        ${total_bill}    Evaluate    int(${total_bill} + ${current_price})

        ${quantity}    Evaluate    str(${product_ids}.count('${id}'))
        ${total_price}    Evaluate    "{:,}".format(int(${current_price} * ${quantity} / 100))

        ${selector_by_row}    Set Variable    tr#CartItem-${index + 1}
        Wait For Elements State    tr#CartItem-${index + 1}    attached

        # validate image
        Get Attribute    ${selector_by_row} ${SELECTOR['img_cart_list']}    
        ...    src    equal    ${src}

        # validate brand
        Get Property    ${selector_by_row} ${SELECTOR['brand_cart_list']}     
            ...    innerText    contains    ${vendor}

        # validate link product
        Get Attribute    ${selector_by_row} ${SELECTOR['link_cart_list']}   
            ...    href    contains    ${url}

        # validate description
        Get Property    ${selector_by_row} ${SELECTOR['desc_cart_list']}    
            ...    innerText    contains    ${title}

        # validate option
        Run Keyword And Ignore Error    
            ...    Get Property    ${selector_by_row} ${SELECTOR['option_cart_list']}   
            ...    innerText    contains    ${option}

        # validate original price
        Run Keyword If    ${original_price} != ${current_price}
            ...    Get Property    ${selector_by_row} ${SELECTOR['old_price_cart_list']}    
            ...    innerText    contains    ฿${old_price}

        # validate final price
        Get Property    ${selector_by_row} ${SELECTOR['final_price_cart_list']}   
            ...    innerText    contains    ฿${final_price}

        # validate quantity
        Get Attribute    ${selector_by_row} ${SELECTOR['quantity_cart_list']}    
            ...    value    equal    ${quantity}

        # validate total price by product
        Get Property    ${selector_by_row} ${SELECTOR['price_end_cart_list']}   
            ...    innerText    contains    ฿${total_price}

    END

    # validate total of bill
    ${total_bill}    Evaluate    "{:,}".format(int(${total_bill} / 100))
    Get Property    ${SELECTOR['total_bill_cart']}    
        ...    innerText    contains    ฿${total_bill}