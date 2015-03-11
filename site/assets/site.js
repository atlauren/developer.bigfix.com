/**
 * Expand all entries on the page.
 */
function expandAll() {
  var hiddenEntries = document.querySelectorAll('.entry-hidden');

  for (var i = 0; i < hiddenEntries.length; i++) {
    hiddenEntries[i]
      .parentElement
      .firstElementChild
      .firstElementChild
      .click();
  }
}

/**
 * Toggle an entry when someone clicks on the +/-.
 */
function toggleEntry(element) {
  var classList = element.firstElementChild.classList;

  if (classList.contains('fa-plus-circle')) {
    classList.remove('fa-plus-circle');
    classList.add('fa-minus-circle');
  } else {
    classList.remove('fa-minus-circle');
    classList.add('fa-plus-circle');
  }

  element.parentElement.nextElementSibling.classList.toggle('entry-hidden');
}

/**
 * Toggle an entry that's linked to when the page loads.
 */
function toggleOnLoad() {
  if (!window.location.hash) {
    return;
  }

  var id = window.location.hash.slice(1);
  var entry = document.getElementById(id);

  if (!entry || !entry.classList.contains('entry')) {
    return;
  }

  var entryHeading = entry.firstElementChild;
  var entryExpand = entryHeading.firstElementChild;

  entryExpand.click();
}

toggleOnLoad();
