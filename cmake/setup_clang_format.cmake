function(stdgpu_setup_clang_format)
    if(STDGPU_ALLOW_NEWER_CLANG_FORMAT_VERSIONS)
        find_package(ClangFormat 18)
    else()
        find_package(ClangFormat 18 EXACT)
    endif()

    if (NOT ClangFormat_FOUND)
        return()
    endif()

    foreach(FILE_EXT IN ITEMS ".h" ".cuh" ".cpp" ".cu" ".hip" ".inc")
        foreach(FILE_DIR IN ITEMS "src" "examples" "benchmarks" "tests")
            file(GLOB_RECURSE SOURCE_FILES_PART LIST_DIRECTORIES FALSE "${FILE_DIR}/*${FILE_EXT}")
            list(APPEND SOURCE_FILES ${SOURCE_FILES_PART})
        endforeach()
        # Collect remaining files in test
        file(GLOB SOURCE_FILES_PART LIST_DIRECTORIES FALSE "test/test_*${FILE_EXT}")
        list(APPEND SOURCE_FILES ${SOURCE_FILES_PART})
    endforeach()

    list(SORT SOURCE_FILES)

    foreach(FILE IN LISTS SOURCE_FILES)
        file(RELATIVE_PATH FILE_REL_PATH "${CMAKE_CURRENT_SOURCE_DIR}" "${FILE}")

        if(STDGPU_COMPILE_WARNING_AS_ERROR)
            set(STDGPU_CLANG_FORMAT_ERROR_FLAG "--Werror")
        endif()

        # Output file will not be generated by clang-format, so the command is always run
        set(DUMMY_CHECK_FILE "${CMAKE_CURRENT_BINARY_DIR}/${FILE_REL_PATH}.check")
        add_custom_command(OUTPUT "${DUMMY_CHECK_FILE}"
                           COMMAND ClangFormat::ClangFormat "--style=file" "--dry-run" ${STDGPU_CLANG_FORMAT_ERROR_FLAG} "${FILE}"
                           COMMENT "Checking code style of ${FILE_REL_PATH}"
                           VERBATIM)
        list(APPEND ALL_DUMMY_CHECK_FILES "${DUMMY_CHECK_FILE}")

        # Output file will not be generated by clang-format, so the command is always run
        set(DUMMY_FORMATTED_FILE "${CMAKE_CURRENT_BINARY_DIR}/${FILE_REL_PATH}.formatted")
        add_custom_command(OUTPUT "${DUMMY_FORMATTED_FILE}"
                           COMMAND ClangFormat::ClangFormat "--style=file" "-i" "${FILE}"
                           COMMENT "Applying code style for ${FILE_REL_PATH}"
                           VERBATIM)
        list(APPEND ALL_DUMMY_FORMATTED_FILES "${DUMMY_FORMATTED_FILE}")
    endforeach()

    add_custom_target(check_code_style
                      DEPENDS "${ALL_DUMMY_CHECK_FILES}")

    add_custom_target(apply_code_style
                      DEPENDS "${ALL_DUMMY_FORMATTED_FILES}")
endfunction()
