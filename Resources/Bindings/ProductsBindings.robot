*** Settings ***
Resource  ../PO/_Keywords/List.robot
Resource  ../PO/_Keywords/Page.robot
Resource  ../PO/_Keywords/Table.robot

*** Keywords ***
### WHEN ###
user adds following number of products to basket: ${amount}  
    PO: Input: Await And Click X Number Of Buttons   InventoryAddToCart  ${amount}
    
    ${product_names}    PO: Common: Get Texts  InventoryItemName  
    ${product_prices}   PO: Common: Get Texts  InventoryItemPrices
    ${product_descs}    PO: Common: Get Texts  InventoryItemDescriptions

    ${current_product_names}   Get Slice From List  ${product_names}   0  ${amount}
    ${current_product_prices}  Get Slice From List  ${product_prices}  0  ${amount}
    ${current_product_descs}   Get Slice From List  ${product_descs}   0  ${amount}

    &{current_shopping_cart}  Create Dictionary
    ...  Names=${current_product_names}
    ...  Prices=${current_product_prices}
    ...  Descriptions=${current_product_descs}

    Set Test Variable  ${current_shopping_cart}

### THEN ###
the shopping cart should contain correct products
    ${product_names}    PO: Common: Get Texts  CartItemNames
    ${product_prices}   PO: Common: Get Texts  CartItemPrices
    ${product_descs}    PO: Common: Get Texts  CartItemDescriptions
    ${count}  Get Length  ${current_shopping_cart}[Names]
    FOR  ${i}  IN RANGE  ${0}  ${count}
        Should Be Equal As Strings  ${product_names}[${i}]   ${current_shopping_cart}[Names][${i}]
        Should Be Equal As Strings  ${product_prices}[${i}]  ${current_shopping_cart}[Prices][${i}]
        Should Be Equal As Strings  ${product_descs}[${i}]   ${current_shopping_cart}[Descriptions][${i}]
    END