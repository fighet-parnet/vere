/// @file

#include "journal.h"

#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "util.h"

//==============================================================================
// FUNCTIONS

int
journal_open(const char *path, journal_t *journal)
{
    if (!path || !journal) {
        errno = EINVAL;
        goto fail;
    }

    int fd = open(path, O_CREAT | O_RDWR, 0644);
    if (fd == -1) {
        fprintf(stderr,
                "journal: failed to open %s: %s\r\n",
                path,
                strerror(errno));
        goto fail;
    }

    struct stat buf;
    if (fstat(fd, &buf) == -1) {
        fprintf(stderr,
                "journal: failed to determine length of %s: %s\r\n",
                path,
                strerror(errno));
        goto close_fd;
    }

    if (buf.st_size % sizeof(journal_entry_t) != 0) {
        fprintf(stderr, "journal: %s is corrupt\r\n", path);
        goto close_fd;
    }

    journal->path      = strdup(path);
    journal->fd        = fd;
    journal->entry_cnt = buf.st_size / sizeof(journal_entry_t);
    return 0;

close_fd:
    close(fd);
fail:
    return -1;
}

int
journal_append(journal_t *journal, const journal_entry_t *entry)
{
    if (!journal || !entry) {
        errno = EINVAL;
        return -1;
    }
    if (write_all(journal->fd, entry, sizeof(*entry)) == -1) {
        return -1;
    }
    journal->entry_cnt++;
    return 0;
}

int
journal_sync(const journal_t *journal)
{
    if (!journal) {
        errno = EINVAL;
        return -1;
    }

    if (fsync(journal->fd) == -1) {
        fprintf(stderr,
                "journal: failed to flush changes to %s: %s\r\n",
                journal->path,
                strerror(errno));
        return -1;
    }

    return 0;
}

int
journal_apply(journal_t *journal, int fd)
{
    if (!journal || journal->fd < 0 || fd < 0) {
        errno = EINVAL;
        return -1;
    }

    if (journal->entry_cnt == 0) {
        return 0;
    }

    if (lseek(journal->fd, 0, SEEK_SET) == (off_t)-1) {
        fprintf(stderr,
                "journal: failed to seek to beginning of %s: %s\r\n",
                journal->path,
                strerror(errno));
        return -1;
    }

    journal_entry_t entry;
    off_t           offset;
    for (size_t i = 0; i < journal->entry_cnt; i++) {
        if (read_all(journal->fd, &entry, sizeof(entry)) == -1) {
            return -1;
        }
        offset = entry.pg_idx * kPageSz;
        if (lseek(fd, offset, SEEK_SET) == (off_t)-1) {
            fprintf(stderr,
                    "journal: failed to seek to offset %u of file descriptor "
                    "%d: %s\r\n",
                    offset,
                    fd,
                    strerror(errno));
            return -1;
        }
        if (write_all(fd, entry.pg, sizeof(entry.pg)) == -1) {
            return -1;
        }
    }

    return 0;
}

void
journal_destroy(journal_t *journal)
{
    if (!journal) {
        return;
    }
    assert(close(journal->fd) == 0);
    assert(unlink(journal->path) == 0);
    free((void *)journal->path);
}
