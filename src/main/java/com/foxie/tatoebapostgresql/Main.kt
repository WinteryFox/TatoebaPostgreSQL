package com.foxie.tatoebapostgresql

import org.apache.commons.compress.archivers.tar.TarArchiveInputStream
import org.apache.commons.compress.compressors.bzip2.BZip2CompressorInputStream
import java.net.URL

fun main() {
    val file = TarArchiveInputStream(
            BZip2CompressorInputStream(
                    URL("https://downloads.tatoeba.org/exports/sentences.tar.bz2")
                            .openStream()
            )
    )
}