// JSDOM não implementa a abertura visual de dialog nativo.
HTMLDialogElement.prototype.showModal = function () { this.setAttribute('open', ''); };
HTMLDialogElement.prototype.close = function () { this.removeAttribute('open'); };
Object.assign(globalThis, { IS_REACT_ACT_ENVIRONMENT: true });
