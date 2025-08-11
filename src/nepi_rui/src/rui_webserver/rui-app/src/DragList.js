/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React from "react"
import Styles from "./Styles"
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd'
//The list prop must be an array of objects with two properties (id and content). 
//Id is how the componet will referenece the object,
//content is the string that will be displayed to users.

//The callback prop is the function that is called after an item is dragged to a new location.
//This function is responsible for updating the list of items with this change.

const DragList = props => {
  const { list, callback, width } = props
  return (
    <DragDropContext onDragEnd={callback}>
        <Droppable droppableId="droppable">
        {(provided, snapshot) => (
            <div
            {...provided.droppableProps}
            ref={provided.innerRef}
            style={{
                border: `1px solid ${Styles.vars.colors.grey1}`,
                width: width,
                marginRight: 0
            }}
            >
            {list.map((item, index) => (
                <Draggable key={item.id} draggableId={item.id} index={index}>
                {(provided, snapshot) => (
                    <div
                    ref={provided.innerRef}
                    {...provided.draggableProps}
                    {...provided.dragHandleProps}
                    style={{
                        textAlign: "center",
                        backgroundColor: Styles.vars.colors.grey0,
                        padding: `${Styles.vars.spacing.xs} ${Styles.vars.spacing.small}`,
                        color: Styles.vars.colors.black,
                        ...provided.draggableProps.style
                    }}
                    >
                    {item.content}
                    </div>
                )}
                </Draggable>
            ))}
            {provided.placeholder}
            </div>
        )}
        </Droppable>
    </DragDropContext>
  )
}

export { DragList }