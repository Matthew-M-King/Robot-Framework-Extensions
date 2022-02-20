*** Settings ***
Resource   ../PageRegistry/_${target_app}Variables.robot
Library    Collections

*** Keywords ***
PO: Definitions: Assert
    ${page}  PO: Page: Get
    ${dicts}  <-  ${${page}_Definitions}
    FOR  ${target_element}  IN  @{dicts.keys()}
        FOR  ${property}  IN  @{dicts.${target_element}.keys()}
            Run Keyword   PO: Definitions: Assert: ${property}   ${target_element}  ${dicts}
        END
    END

PO: Definitions: Assert: ShouldContain
    [Arguments]  ${target_element}  ${definitions}
    ${expected_text}  <-  ${definitions.${target_element}.ShouldContain}
    PO: Common: Locator Should Contain Value  ${target_element}  ${expected_text}

PO: Definitions: Assert: EachInGroupShouldContain
    [Arguments]  ${target_element}  ${definitions}
    @{results}  Create List
    ${text_list}  <-  ${definitions}[${target_element}][EachInGroupShouldContain]
    ${result_text}  <-  ${NONE}

    ${i}  <-  ${1}
    FOR  ${expected_text}  IN  @{text_list}
        ${locator}  Build Locator: Update Parent With Index  ${target_element}  ${i}
        
        ${result_locator}  ${actual_text}   Run Keyword And Ignore Error  Get Text  ${locator}
        
        IF  "${result_locator}"=="PASS"
            ${result_text}  ${junk}  Run Keyword And Ignore Error  Should Be Equal As Strings  ${expected_text}  ${actual_text}
        END
        
        ${i}  Evaluate  ${i}+1
        IF  "${result_text}"=="FAIL"  
            ${msg}  <-  FAIL - Expected locator ${locator} to contain text "${expected_text}" but contained "${actual_text}"
            Append To List  ${results}  ${msg}
        ELSE IF  "${result_locator}"=="FAIL"
            Append To List  ${results}  FAIL - ${actual_text}
        END
    END
    Return From Keyword IF  not ${results}

    FOR  ${msg}  IN  @{results}
        Log  ${msg}  WARN
    END
    Fail   Element attributes/content for locator group did not match definition

PO: Definitions: Assert: ElementCountShouldBe
    [Arguments]  ${target_element}  ${definitions}
    FOR  ${target_element}  IN  @{definitions.keys()}
        ${locator}  Build Locator  ${target_element}
        ${count}  <-  ${definitions}[${target_element}][ElementCountShouldBe]
        Page Should Contain Element  ${locator}  limit=${count}
    END

PO: Definitions: Assert: TableContentShouldBe
    [Arguments]  ${target_element}  ${definitions}
    ${target_element_def}  <-  ${definitions}[${target_element}]
    ${target_content_def}  <-  ${target_element_def}[TableContentShouldBe]
    ${table_content}       <-  ${target_content_def}[Columns]
    ${result}   PO: Table: Assert Table Content  ${target_element}   ${table_content}
    IF    not ${result}
        Fail    Table content or table definition was incorrect
    END

PO: Definitions: Assert: ImageGroupAttributes
    [Arguments]  ${target_element}  ${definitions}
    ${target_element_def}  <-  ${definitions}[${target_element}]
    ${image_properties_list}    <-  ${target_element_def.ImageGroupAttributes}
    FOR  ${img_name}  IN  @{image_properties_list}
        ${properties}  <-  ${image_properties_list}[${img_name}]
        ${locator}  Build Locator: Update Parent With Index  ${target_element}  ${properties}[DefaultOrder]
        Element Attribute Value Should Be  ${locator}//img  attribute=alt  expected=${properties}[Alt]
        Element Attribute Value Should Be  ${locator}//img  attribute=src  expected=${BaseUrl}${properties}[Src]
    END