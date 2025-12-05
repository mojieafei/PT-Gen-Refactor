import { handleRequest } from "./lib/utils.js";

export default {
  fetch(request, env) {
    return handleRequest(request, env);
  }
};