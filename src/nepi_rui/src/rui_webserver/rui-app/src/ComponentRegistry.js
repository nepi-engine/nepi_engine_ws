// ComponentRegistry.js
const ComponentRegistry = {};

export function registerComponent(name, component) {
  ComponentRegistry[name] = component;
}

export function getComponent(name) {
  return ComponentRegistry[name];
}
