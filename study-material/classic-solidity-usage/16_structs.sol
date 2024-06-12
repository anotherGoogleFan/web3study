/*
You can define your own type by creating a struct.

They are useful for grouping together related data.

Structs can be declared outside of a contract and imported in another contract.
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Todos {
    struct Todo {
        string text;
        bool completed;
    }

    // an array of Todo
    Todo[] public todos;

    function create(string calldata _text) public {
        // 3 ways to initialize a struct
        // - calling it like a function
        todos.push(Todo(_text, false));

        // key value mapping
        Todo memory todo;
        todo.text = _text;
        // todo.completed initialize to false

        todos.push(todo);
    }

    // Solidity automatically created a getter for 'todos' so
    // you don't actually need this function.
    function get(uint256 _idx) public view returns (string memory, bool) {
        require(_idx < todos.length, "idx too big");
        Todo memory todo = todos[_idx];
        return (todo.text, todo.completed);
    }

    // update text
    function updateText(uint256 _idx, string calldata _text) public {
        require(_idx < todos.length, "idx too big");
        todos[_idx].text = _text;
    }

    // update completed
    function toggleCompleted(uint256 _idx) public {
        require(_idx < todos.length, "idx too big");
        todos[_idx].completed = !todos[_idx].completed;
    }
}
