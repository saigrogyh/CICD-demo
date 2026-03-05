//pipeline {
//    agent any
//
//    stages {
//
//
//        // ด่านที่ 1: ตรวจสอบความถูกต้องของโค้ด
//        stage('1. Unit Test (QC Code)') {
//            steps {
//                echo '🧪 กำลังรัน Unit Test เพื่อตรวจสอบความถูกต้องของลอจิก...'
//                sh 'chmod +x mvnw'
//                sh './mvnw test'
//            }
//        }
//
//        // ด่านที่ 2: ประกอบร่างแอป
//        stage('2. Build JAR') {
//            steps {
//                echo '🚀 กำลัง Build โค้ด Spring Boot (สร้างไฟล์ .jar)...'
//                sh './mvnw clean package -DskipTests'
//            }
//        }
//
//        // ด่านที่ 3: แพ็กใส่กล่อง Docker
//        stage('3. Build Docker Image') {
//            steps {
//                echo '📦 กำลังเอาไฟล์ .jar ยัดใส่ Docker Image...'
//                sh 'docker build -t springboot-api:latest .'
//            }
//        }
//
//        // ด่านที่ 4: ท่าไม้ตาย Zero Downtime (Rolling Update)
//        stage('4. Deploy') {
//            steps {
//                echo '🚚 กำลังเซฟ Image...'
//                sh 'docker save -o springboot-api.tar springboot-api:latest'
//
//                script {
//                    // รายชื่อเซิร์ฟเวอร์หลังบ้านของเรา
//                    def servers = ['192.168.64.3', '192.168.64.4']
//
//                    for (ip in servers) {
//                        echo "======================================"
//                        echo "🚀 กำลัง Deploy แบบ Rolling Update ไปที่ ${ip}..."
//                        echo "======================================"
//
//                        // 1. โยนไฟล์ข้ามเครื่อง
//                        sh "sshpass -p 'yorchgeorge' scp -o StrictHostKeyChecking=no springboot-api.tar yorch@${ip}:/home/yorch/"
//
//                        // 2. สั่งรัน + ใส่เกราะ --restart always
//                        sh """
//                        sshpass -p 'yorchgeorge' ssh -o StrictHostKeyChecking=no yorch@${ip} '
//                            echo yorchgeorge | sudo -S docker load -i /home/yorch/springboot-api.tar &&
//                            echo yorchgeorge | sudo -S docker stop springboot-api || true &&
//                            echo yorchgeorge | sudo -S docker rm springboot-api || true &&
//                            echo yorchgeorge | sudo -S docker run -d -p 8080:8080 --name springboot-api --restart always springboot-api:latest
//                        '
//                        """
//
//                        echo "⏳ รอ 20 วินาที ให้ Spring Boot บน ${ip} พร้อมรับลูกค้า..."
//                        sleep 20
//                    }
//                }
//            }
//        }
//    }
//}


pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['DEPLOY', 'ROLLBACK'], description: 'บอสจะลงของใหม่หรือย้อนกลับ?')
        string(name: 'VERSION', defaultValue: '', description: 'ถ้า Rollback ใส่เลข Build ที่ต้องการ (เช่น 1, 2)')
    }

    environment {
        DOCKER_IMAGE = "noppawut483/spring-app-cicd"
        DOCKER_HUB_CRED = 'docker-hub-credentials'
    }

    stages {
        stage('Initialize') {
            steps {
                script {
                    // กำหนดเลขเวอร์ชัน
                    env.TARGET_VER = (params.ACTION == 'DEPLOY') ? env.BUILD_NUMBER : params.VERSION

                    if (params.ACTION == 'ROLLBACK' && params.VERSION == '') {
                        error "บอสลืมใส่เลขเวอร์ชันที่จะถอยกลับครับ!"
                    }
                }
            }
        }

        stage('Build & Push Image') {
            when { expression { params.ACTION == 'DEPLOY' } }
            steps {
                echo "กำลังสร้าง Image รุ่นที่ ${env.TARGET_VER}..."
                sh "./mvnw clean package -DskipTests"

                script {
                    // Login และ Push ขึ้น Docker Hub
                    docker.withRegistry('', env.DOCKER_HUB_CRED) {
                        def appImage = docker.build("${env.DOCKER_IMAGE}:${env.TARGET_VER}")
                        appImage.push()
                    }
                }
            }
        }

        stage('Deploy to Servers') {
            steps {
                script {
                    def ips = ['192.168.64.3', '192.168.64.4']
                    ips.each { ip ->
                        echo "กำลังอัปเดตเครื่อง ${ip}..."
                        sh """
                        sshpass -p 'yorchgeorge' ssh -o StrictHostKeyChecking=no yorch@${ip} '
                            docker pull ${env.DOCKER_IMAGE}:${env.TARGET_VER} &&
                            docker stop springboot-api || true &&
                            docker rm springboot-api || true &&
                            docker run -d -p 8080:8080 --name springboot-api --restart always ${env.DOCKER_IMAGE}:${env.TARGET_VER}
                        '
                        """
                        // ตอบคำถามบอสเรื่อง Sleep อยู่ตรงนี้ครับ!
                        echo "⏳ รอ 15 วินาที ให้เครื่อง ${ip} สตาร์ทแอปให้เสร็จก่อนไปเครื่องถัดไป..."
                        sleep 15
                    }
                }
            }
        }

        stage('Nginx Reload') {
            steps {
                sh "docker exec nginx-lb nginx -s reload"
                echo "เรียบร้อย! เข้าดูผลงานที่ Ngrok ได้เลยครับบอส"
            }
        }
    }
}