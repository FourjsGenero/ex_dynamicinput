IMPORT util

MAIN
DEFINE field_count INTEGER
DEFINE column_count INTEGER
DEFINE page_mode BOOLEAN
DEFINE page_size INTEGER

    OPTIONS FIELD ORDER FORM
    OPTIONS INPUT WRAP

    CALL ui.Interface.loadStyles("dynamic_input")
    
    CLOSE WINDOW SCREEN

    -- Initial values
    LET field_count = 12
    LET column_count = 3
    LET page_mode = FALSE
    LET page_size = 6
    
    OPEN WINDOW p WITH FORM "dynamic_input"
    INPUT BY NAME field_count, column_count, page_mode, page_size ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS=TRUE, ACCEPT=FALSE, CANCEL=FALSE)
        BEFORE INPUT
            CALL DIALOG.setFieldActive("formonly.page_size", page_mode)
            
        ON CHANGE page_mode -- page size only matters if in page mode
            CALL DIALOG.setFieldActive("formonly.page_size", page_mode)
            
        ON ACTION run
            CALL do_dynamic_input(field_count, column_count, page_mode, page_size)
            
        ON ACTION close
            EXIT INPUT
    END INPUT
END MAIN



FUNCTION do_dynamic_input(field_count, column_count, page_mode, page_size )
DEFINE field_count INTEGER
DEFINE column_count INTEGER
DEFINE page_mode BOOLEAN
DEFINE page_size INTEGER

DEFINE d ui.Dialog
DEFINE fields DYNAMIC ARRAY OF RECORD
    name STRING,
    type STRING
END RECORD

DEFINE i INTEGER
DEFINE event STRING

DEFINE page INTEGER
DEFINE idx INTEGER
DEFINE value INTEGER

DEFINE page_count INTEGER
DEFINE min_field, max_field INTEGER

DEFINE values DYNAMIC ARRAY OF INTEGER

    -- Dummy data
    FOR i = 1 TO field_count
        LET values[i] = util.Math.rand(100)
    END FOR

    IF page_mode THEN
        LET page_count = ((field_count-1) / page_size)+1
    ELSE
        LET page_count = 1
        LET page_size = field_count
    END IF

    OPEN WINDOW dynamic_input WITH 1 ROWS, 1 COLUMNS ATTRIBUTES(TEXT="Dynamic Input Form Example")

    LET page = 1
    
    WHILE TRUE
        -- Determine field range
        LET min_field = (page-1) * page_size +1
        LET max_field = page * page_size
        IF max_field > field_count THEN
            LET max_field = field_count
        END IF
        
        CALL create_form(field_count,column_count, page_mode, page_size, page)

        -- Define field list
        CALL fields.clear()
        FOR i = min_field TO max_field
            LET fields[i-min_field+1].name = field_indexed_name("qty", i)
            LET fields[i-min_field+1].type = "INTEGER"
        END FOR

        -- Build dialog
        LET d = ui.Dialog.createInputByName(fields)
        CALL d.addTrigger("ON ACTION close")
        IF page_mode THEN
            FOR i =  1 TO page_count
                CALL d.addTrigger(SFMT("ON ACTION page%1", i USING "&&&"))
            END FOR
        END IF
        
        -- Simulate reading values from database
        FOR i = min_field TO max_field
            CALL d.setFieldValue(field_indexed_name("qty",i), values[i])
        END FOR

        -- Add events
        WHILE TRUE  
            LET event = d.nextEvent()
            CASE 
                WHEN event = "ON ACTION close"
                    LET int_flag = TRUE
                    EXIT WHILE

                -- User changes value in field
                WHEN event MATCHES "ON CHANGE qty*"
                    LET idx = event.subString(14,event.getLength())
                    LET value = d.getFieldValue(field_indexed_name("qty",idx))
                    LET values[idx] = value
                    MESSAGE SFMT("Field qty%1 changed, new value is %2", idx,value)

                -- In page moade, user selects another page
                WHEN event MATCHES "ON ACTION page*" 
                    LET page = event.subString(15, event.getLength())
                    EXIT WHILE
            END CASE
        END WHILE
        CALL d.close()

        IF int_flag THEN
            EXIT WHILE
        END IF
        
    END WHILE
    LET int_flag = 0
    CLOSE WINDOW dynamic_input
END FUNCTION



FUNCTION create_form(field_count, column_count, page_mode, page_size, page )
DEFINE field_count INTEGER
DEFINE column_count INTEGER
DEFINE page_mode BOOLEAN
DEFINE page_size INTEGER
DEFINE page INTEGER

DEFINE x, y, idx INTEGER
DEFINE row_size INTEGER

DEFINE w ui.Window
DEFINE f ui.Form
DEFINE form_node, vbox_node, hbox_node, group_node, grid_node, label_node, form_field_node, widget_node om.DomNode
DEFINE width, height INTEGER

    
    LET w = ui.Window.getCurrent()
    LET f = w.createForm("dynamic_input")
    
    LET form_node = f.getNode()

    --Layout
    --VBox
    LET vbox_node = form_node.createChild("VBox")
    CALL vbox_node.setAttribute("name","vbox")
    IF page_mode THEN
        LET row_size = ((page_size-1) / column_count) + 1
    ELSE
        LET row_size = ((field_count-1) / column_count) + 1
    END IF
    LET idx = (page-1)*page_size
    LET height = 0
    LET width = 0
    FOR y = 1 TO row_size
        LET height = height + 2
        
        LET hbox_node = vbox_node.createChild("HBox")
        FOR x = 1 TO column_count
            IF x = 1 THEN -- Only need to calc once
                LET width = width + 10
            END IF
            LET idx = idx + 1
            
            --Group
            LET group_node = hbox_node.createChild("Group")
            --Grid
            LET grid_node = group_node.createChild("Grid")
            IF idx <= field_count THEN
                --Fields
                LET label_node = grid_node.createChild("Label")
                CALL label_node.setAttribute("posX",1)
                CALL label_node.setAttribute("posY",1)
                CALL label_node.setAttribute("text",SFMT("Field %1", idx USING"##&"))

                LET form_field_node = grid_node.createChild("FormField")
                CALL form_field_node.setAttribute("colName",field_indexed_name("qty",idx))
                CALL form_field_node.setAttribute("name",field_indexed_name("formonly.qty",idx))
                CALL form_field_node.setAttribute("tabIndex",idx)

                LET widget_node = form_field_node.createChild("SpinEdit")
                CALL widget_node.setAttribute("posX",1)
                CALL widget_node.setAttribute("posY",2)
                CALL widget_node.setAttribute("width",10)
                CALL widget_node.setAttribute("height","1")
            END IF
            
        END FOR
    END FOR
    IF page_mode THEN
        -- Add buttons to navigate to each page
        LET hbox_node = vbox_node.createChild("HBox")
        FOR idx = 1 TO ((field_count-1) / page_size)+1
            LET grid_node = hbox_node.createChild("Grid")
            LET widget_node = grid_node.createChild("Button")
            CALL widget_node.setAttribute("name",SFMT("page%1", idx USING "&&&"))
            CALL widget_node.setAttribute("text",SFMT("%1-%2", (idx-1) * page_size +1, IIF((idx * page_size)<field_count, (idx*page_size), field_count)))
            CALL widget_node.setAttribute("style","link")
        END FOR
    END IF
    CALL form_node.setAttribute("width",width)
    CALL form_node.setAttribute("height",height)
    
END FUNCTION



FUNCTION field_indexed_name(field_name,x)
DEFINE field_name STRING
DEFINE x INTEGER

    RETURN SFMT("qty%1", x USING "&&&")
END FUNCTION