# Fire-Logs

### A Mobile application built with flutter and firebase.

---

##### Features:

- An authentication system to help user to identify and sync logs in real-time.

- No backup is created on the system, which means no consuming storage while sitting idle in the memory.

- A trash system that keeps the deleted logs from the main page to let user able to backup when needed.

- A sync button on the main page for manual syncing.

##### Keep in mind:

- App ony keeps the notes in cloud so it can't be accessed if there is no connection.

- All the other features would work even if there is no connection, but created log won't be added until there is an connection while pushing the save button.

- The welcome note cannot be deleted, and also cannot be edited. This helps in keeping the user's account in the cloud.

###### Bugs introduced:

- notification toast shows up again and again while toggling between authentication options.

- No listener created for internet connections, so app puts itself in infinite loading animations till the connection is created again.

##### Features yet to be added:

- A connection listener to correctly give user the reason of no content on screen.

- Animated splash screen.

- Link, rich-text format, and images.

- Private folders with password protection.
