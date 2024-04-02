package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

base_path :: "/home/mhenn/Documents/repos/TicketSystem/services/ticket/client/src/"

File :: struct {
    details: os.File_Info,
    imports: []string,
}

dir_files :: proc(file: os.File_Info) -> []os.File_Info {
    if !file.is_dir {
        return nil
    }
    dir_handle, handle_err := os.open(file.fullpath)
    files, file_err := os.read_dir(dir_handle, 1)
    return files[:]
}

get_vue_files :: proc() -> []os.File_Info {
    files := make([dynamic]os.File_Info)
    vue_files := make([dynamic]os.File_Info)
    defer delete(files)

    dir_handle, handle_err := os.open(base_path)
    src_files, file_err := os.read_dir(dir_handle, 1)

    append(&files, ..src_files[:])

    for file in files {
        if strings.contains(file.name, ".vue") {
            append(&vue_files, file)

        } else {
            append(&files, ..dir_files(file))
        }
    }
    return vue_files[:]
}

get_imports_for_file :: proc(file: os.File_Info) -> File {
    data, ok := os.read_entire_file(file.fullpath)
    it := string(data)
    imports := slice.filter(
        strings.split_lines(it),
        proc(line: string) -> bool {
            return strings.contains(line, "import")
        },
    )
    mapped := slice.mapper(imports, proc(import: rune) {}) 

    return File{file, imports}
}



main :: proc() {
    files := make([dynamic]os.File_Info)
    defer delete(files)
    append(&files, ..get_vue_files())

    for file in files {
        fmt.println(file.name)
    }
    file := get_imports_for_file(files[1])
    fmt.println(file.imports)
}
