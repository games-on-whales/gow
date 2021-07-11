function createGiscusEl() {
    let scr = document.createElement('script');

    scr.src = "https://giscus.app/client.js"
    scr.crossOrigin = "anonymous"
    scr.async = true

    scr.setAttribute("data-repo", "games-on-whales/gow")
    scr.setAttribute("data-repo-id", "MDEwOlJlcG9zaXRvcnkzNzYzMDczODk=")
    scr.setAttribute("data-category", "Documentation")
    scr.setAttribute("data-category-id", "DIC_kwDOFm3-vc4B-QM2")
    scr.setAttribute("data-mapping", "pathname")
    scr.setAttribute("data-reactions-enabled", "1")
    scr.setAttribute("data-theme", "dark_dimmed")

    // We have to put this where it'll not be removed
    // Unfortunately <footer> is inside main-content and will be remove on each load
    document.querySelector("#top").append(scr);
}

function reloadGiscus() {
    let frame = document.querySelector("iframe.giscus-frame");

    // Took this from https://giscus.app/client.js
    let term = location.pathname.length < 2 ? 'index' : location.pathname.substr(1).replace(/\.\w+$/, '');

    frame.contentWindow.postMessage({
        giscus: {
            setConfig: {
                term: term,
                repo: "games-on-whales/gow",
            }
        }},
        'https://giscus.app')
}

// Set the link element as active to provide user feedback
function setActive(element) {
    element.classList.add("active");
    element.parentElement.classList.add("active");

    let parent_collection = element.closest("li.nav-list-item").parentElement.closest("li.nav-list-item");
    if (parent_collection !== null) {
        parent_collection.classList.add("active");
    }
}

function removeAllActive() {
    document.querySelectorAll(".active").forEach(el => {
        el.classList.remove("active");
    })
}

document.addEventListener('DOMContentLoaded', (event) => {
    Barba.Pjax.Dom.containerClass = 'main-content';
    Barba.Pjax.Dom.wrapperId = 'main-content-wrap';

    Barba.Pjax.start();

    createGiscusEl();

    // This works both on click and on history back/forward
    Barba.Dispatcher.on('transitionCompleted', (currentStatus) => {
        removeAllActive();
        document.querySelectorAll("a.nav-list-link").forEach(element => {
            if (element.href == currentStatus.url) {
                setActive(element);
            }
        });
        reloadGiscus();
    });


})