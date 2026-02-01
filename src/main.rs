use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};
use std::process::Command;
use serde_json::Value;

// URL එක ගන්න structure එක
#[derive(Deserialize)]
struct Info {
    url: String,
}

// 1. Health Check (Koyeb එකට)
#[get("/")]
async fn index() -> impl Responder {
    HttpResponse::Ok().body("Rust Server is Running! 🦀🚀")
}

// 2. Download API
#[get("/api/download")]
async fn download_video(info: web::Query<Info>) -> impl Responder {
    let video_url = &info.url;

    // yt-dlp command එක run කරනවා
    // -j කියන්නේ JSON output දෙන්න කියල
    let output = Command::new("yt-dlp")
        .arg("-j") 
        .arg("--no-playlist")
        .arg("--quiet")
        .arg(video_url)
        .output();

    match output {
        Ok(o) => {
            if o.status.success() {
                // yt-dlp එකෙන් ආපු JSON text එක කියවනවා
                let output_str = String::from_utf8_lossy(&o.stdout);
                
                // ඒක JSON object එකක් බවට හරවනවා
                let json_result: Result<Value, _> = serde_json::from_str(&output_str);

                match json_result {
                    Ok(v) => {
                        // අපිට ඕන දේවල් ටික විතරක් ෆිල්ටර් කරලා යවනවා
                        let response = serde_json::json!({
                            "status": "success",
                            "title": v["title"],
                            "duration": v["duration"],
                            "thumbnail": v["thumbnail"],
                            "direct_url": v["url"]
                        });
                        HttpResponse::Ok().json(response)
                    },
                    Err(_) => HttpResponse::InternalServerError().json(serde_json::json!({"error": "Failed to parse JSON form yt-dlp"}))
                }
            } else {
                let err_str = String::from_utf8_lossy(&o.stderr);
                HttpResponse::BadRequest().json(serde_json::json!({"error": "Download failed", "details": err_str}))
            }
        },
        Err(e) => HttpResponse::InternalServerError().json(serde_json::json!({"error": "Failed to execute command", "details": e.to_string()}))
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Port එක Environment variable එකෙන් ගන්නවා (Koyeb compatibility)
    let port = std::env::var("PORT")
        .unwrap_or_else(|_| "8000".to_string())
        .parse()
        .expect("PORT must be a number");

    println!("Server running on port {}", port);

    HttpServer::new(|| {
        App::new()
            .service(index)
            .service(download_video)
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
