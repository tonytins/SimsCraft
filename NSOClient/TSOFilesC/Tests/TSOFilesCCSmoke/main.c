#include <TSOFilesC.h>

#include <assert.h>
#include <stddef.h>
#include <stdint.h>

static void write_u32_le(uint8_t *bytes, size_t offset, uint32_t value) {
    bytes[offset] = (uint8_t)value;
    bytes[offset + 1] = (uint8_t)(value >> 8);
    bytes[offset + 2] = (uint8_t)(value >> 16);
    bytes[offset + 3] = (uint8_t)(value >> 24);
}

int main(void) {
    const uint8_t compressed[] = {0x0E, 0x01, 0x61, 0x62, 0xFC, 0x00, 0x00};
    uint8_t *output = 0;
    int64_t output_size = 0;

    int32_t status = tsofiles_c_refpack_decompress(
        compressed, (int64_t)sizeof(compressed), 8, &output, &output_size);
    assert(status == TSOFILES_C_OK);
    assert(output_size == 8);
    assert(output[0] == 'a' && output[1] == 'b' && output[7] == 'b');
    tsofiles_c_buffer_free(output);

    uint8_t dbpf[71] = {'D', 'B', 'P', 'F'};
    write_u32_le(dbpf, 4, 1);
    write_u32_le(dbpf, 8, 0);
    write_u32_le(dbpf, 24, 1000);
    write_u32_le(dbpf, 28, 2000);
    write_u32_le(dbpf, 32, 7);
    write_u32_le(dbpf, 36, 1);
    write_u32_le(dbpf, 40, 51);
    write_u32_le(dbpf, 44, 20);
    dbpf[48] = 'S';
    dbpf[49] = 'F';
    dbpf[50] = 'X';
    write_u32_le(dbpf, 51, 0x1D07EB4B);
    write_u32_le(dbpf, 55, 0x9DBDBF89);
    write_u32_le(dbpf, 59, 12);
    write_u32_le(dbpf, 63, 48);
    write_u32_le(dbpf, 67, 3);

    TSOFilesCArchive *archive = 0;
    status = tsofiles_c_dbpf_open(dbpf, (int64_t)sizeof(dbpf), &archive);
    assert(status == TSOFILES_C_OK);
    assert(archive != 0);

    uint32_t major_version = 0;
    uint32_t minor_version = 0;
    assert(tsofiles_c_dbpf_version(archive, &major_version, &minor_version) == TSOFILES_C_OK);
    assert(major_version == 1 && minor_version == 0);

    int64_t entry_count = 0;
    assert(tsofiles_c_dbpf_entry_count(archive, &entry_count) == TSOFILES_C_OK);
    assert(entry_count == 1);

    int64_t entry_index = -1;
    assert(tsofiles_c_dbpf_find_entry(archive, 12, 0x1D07EB4B, &entry_index) == TSOFILES_C_OK);
    assert(entry_index == 0);

    uint32_t type_id = 0;
    uint32_t group_id = 0;
    uint32_t instance_id = 0;
    uint32_t file_offset = 0;
    uint32_t file_size = 0;
    assert(tsofiles_c_dbpf_entry_at(
        archive, entry_index, &type_id, &group_id, &instance_id, &file_offset, &file_size) == TSOFILES_C_OK);
    assert(type_id == 0x1D07EB4B && group_id == 0x9DBDBF89);
    assert(instance_id == 12 && file_offset == 48 && file_size == 3);

    uint8_t *entry_data = 0;
    int64_t entry_data_size = 0;
    assert(tsofiles_c_dbpf_entry_data(archive, entry_index, &entry_data, &entry_data_size) == TSOFILES_C_OK);
    assert(entry_data_size == 3);
    assert(entry_data[0] == 'S' && entry_data[1] == 'F' && entry_data[2] == 'X');
    tsofiles_c_buffer_free(entry_data);
    tsofiles_c_dbpf_close(archive);

    const uint8_t not_dbpf[] = {'N', 'O', 'P', 'E'};
    archive = 0;
    status = tsofiles_c_dbpf_open(not_dbpf, (int64_t)sizeof(not_dbpf), &archive);
    assert(status == TSOFILES_C_DBPF_NOT_ARCHIVE);
    assert(archive == 0);
    tsofiles_c_dbpf_close(archive);

    return 0;
}
