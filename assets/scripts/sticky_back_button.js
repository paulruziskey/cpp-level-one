const backButtons = [];
for (const button of document.getElementsByClassName('back-button')) {
    backButtons.push(
        {
            button: button,
            absoluteTopOffset: button.offsetTop,
        }
    );
}

window.onscroll = () => {
    for (const { button, absoluteTopOffset } of backButtons) {
        if (window.scrollY + 30 > absoluteTopOffset) {
            button.classList.add('back-button-fixed');
            button.classList.remove('back-button');
        } else {
            button.classList.remove('back-button-fixed');
            button.classList.add('back-button');
        }
    }
};
