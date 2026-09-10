do
    --[[
        Doubly-Linked List v1.3.0.0 by Wrda, Eikonium and Bribe
        ------------------------------------------------------------------------------
        A script that allows the possibility to create a sequence of any object
        linked together.
        ------------------------------------------------------------------------------
    API:
        LinkedList.create(head) -> LinkedList
        - Creates or resets a table as a LinkedList head.
        - Allows a user-specified head or generates a new one.

        list:insert([node_or_value, after]) -> listNode
        - Inserts *before* the given list/node unless "after" is true.
        - If a "node or value" is passed, the system will check if the node is
          a table. If the table isn't yet part of a LinkedList structure, it
          will be converted into the node that is returned at the end of this
          function. If the table is a part of the LinkedList structure, or a
          different type of value than a table, then it will be assigned as a
          generic "value" (mapped to node.value)
        - Returns the inserted node that was added to the list (if addition was successful).

        list:remove(node) -> boolean
        - Removes a node from whatever list it is a part of and calls self:onRemove().
        - Returns true if it was sucessful.

        for node in list:loop([backwards]) do [stuff] end
        - Iterates over all nodes in "list".

        fromList:merge(intoList[, backwardsFrom, backwardsInto])
        - Removes all nodes from one list and adds them into another.

        list:reset() -> boolean
        - Removes all nodes from the given linked list, calling node:onRemove() on each.
        - Returns true if sucessful.

        - readonly list.n : integer -> the number of nodes in the list.
    ]]
    ---@class LinkedList:table
    ---@field head LinkedList
    ---@field next listNode|LinkedList
    ---@field prev listNode|LinkedList
    ---@field n integer
    LinkedList = {}
    LinkedList.__index = LinkedList

    ---@class listNode:LinkedList
    ---@field value? any
    ---@field remove fun(node:listNode)->boolean
    ---@field onRemove fun(self:listNode)

    ---Creates or resets a table as a LinkedList head.
    ---@param head? LinkedList allows a user-specified head or generates a new one.
    ---@return LinkedList?
    function LinkedList.create(head)
        if head and type(head) == "table" then
            local h = head.head
            if h then
                if h ~= head then
                    return nil --user passed an active ListNode. This is not allowed.
                end
                if h.n > 0 then --first empty any lists that still have nodes.
                    for node in head:loop() do
                        node:onRemove()
                    end
                end
            end
        else
            ---@diagnostic disable-next-line: missing-fields
            head = {}
        end
        setmetatable(head, LinkedList)
        head.next = head
        head.prev = head
        head.head = head
        head.n = 0
        return head
    end

    ---Node can be an existing table, or a new table will be created to represent the
    ---node. "list" can either be the head, or any point where you want the node to be
    ---inserted. It will insert *before* the given head/node, unless "backward" is true.
    ---@param list listNode|LinkedList
    ---@param node_or_value? any
    ---@param insertAfter? boolean
    ---@return listNode? node that was added to the list (if addition was successful)
    function LinkedList.insert(list, node_or_value, insertAfter)
        if not list then
            return nil
        end
        local head = list.head
        if not head then
            return nil
        end
        local node, value

        if node_or_value then
            if type(node_or_value) == "table" then
                if node_or_value.head then --table is already part of a linked list. Treat it as a "value"
                    value = node_or_value
                else
                    node = node_or_value --table will be transmuted into the linked list node itself.
                end
            else
                --User passed a non-table value.
                value = node_or_value
            end
        end
        if insertAfter then
            list = list.next
        end

        node = node or {} ---@type listNode
        setmetatable(node, LinkedList)
        list.prev.next = node
        node.prev = list.prev
        list.prev = node
        node.next = list
        node.head = head
        head.n = head.n + 1
        node.value = value
        node.onRemove = function()
            node.head = nil
        end
        return node
    end

    ---Removes a node from whatever list it is a part of. A node cannot be a part of
    ---more than one list at a time, so there is no need to pass the containing list as
    ---an argument.
    ---@param node listNode
    ---@return boolean wasRemoved
    function LinkedList:remove(node)
        node = node or self
        if node then
            local head = node.head
            if head and head ~= node then
                node.prev.next = node.next
                node.next.prev = node.prev
                head.n = head.n - 1
                node:onRemove()
                return true
            end
        end
        return false
    end

    ---Enables the generic for-loop for LinkedLists.
    ---Syntax: "for node in LinkedList.loop(list) do print(node) end"
    ---Alternative Syntax: "for node in list:loop() do print(node) end"
    ---@param list LinkedList
    ---@param backward? boolean
    function LinkedList.loop(list, backward)
        list = list.head
        local loopNode = list ---@type listNode
        local direction = backward and "prev" or "next"
        return function()
            loopNode = loopNode[direction]
            return loopNode ~= list and loopNode or nil
        end
    end

    ---Merges LinkedList "from" to another LinkedList "into"
    ---@param from LinkedList|listNode
    ---@param into LinkedList|listNode
    ---@param backwardFrom boolean
    ---@param backwardInto boolean
    function LinkedList.merge(from, into, backwardFrom, backwardInto)
        if from and from.head and into and into.head then
            local directionFrom = backwardFrom and "prev" or "next"
            local n, v
            local node = from[directionFrom]
            from = from.head
            while node ~= from do
                n, v = node[directionFrom], node.value
                node:remove()
                into:insert(node, backwardInto).value = v
                node = n
            end
        end
    end

    ---Removes all nodes from the given linked list.
    ---@param list LinkedList
    ---@return boolean was_reset
    function LinkedList.reset(list)
        return list:create() ~= nil
    end
end
