--!strict
-- Fictional dialogue for the educational prototype; not a historical quotation.
return {
    LetterFound = {
        speaker = "SURAT PENTING",
        lines = {
            "Kamu menemukan surat yang ditujukan kepada penjaga pos pejuang.",
            "Bawa surat ini ke pos di ujung jalan. Jalur pengungsian masih ditutup.",
        },
    },
    NoLetter = {
        speaker = "PENJAGA POS",
        lines = {"Kami menunggu surat penting. Coba periksa meja di dekat rumah warga, lalu kembali ke pos ini."},
    },
    LetterDelivered = {
        speaker = "PENJAGA POS",
        lines = {
            "Terima kasih. Suratnya sudah saya terima.",
            "Gerbang jalur pengungsian dibuka. Silakan lanjutkan perjalanan dengan hati-hati.",
        },
    },
    AlreadyDelivered = {
        speaker = "PENJAGA POS",
        lines = {"Surat darimu sudah kami terima. Jalur pengungsian telah dibuka."},
    },
    GateLocked = {
        speaker = "GERBANG PENGUNGSIAN",
        lines = {"Gerbang masih terkunci. Serahkan surat penting kepada penjaga pos untuk membuka jalur ini."},
    },
}
