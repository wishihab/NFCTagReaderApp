/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
The view controller that scans and displays NDEF messages.
*/

import UIKit
import CoreNFC

/// - Tag: MessagesTableViewController
class MessagesTableViewController: UITableViewController, NFCTagReaderSessionDelegate {

    // MARK: - Properties

    let reuseIdentifier = "reuseIdentifier"
    var detectedMessages = [NFCNDEFMessage]()
    var session: NFCTagReaderSession?
    let iso7816AIDs = ["A000000018434D00", "A000000003000000", "A000000151000000"]
    
    //A000000018434D00 flazz
    //A000000003000000 jakcard dki debit
    //A000000003000000 also bca debit but cant read
    //A000000151000000 mandiri debit

    // MARK: - Actions

    /// - Tag: beginScanning
    @IBAction func beginScanning(_ sender: Any) {
        //print("Starting ISO7816 scan")
        print("Popup NFC or TAG reader")
        guard NFCTagReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        // Start ISO7816 session with ISO14443 polling
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "Hold your iPhone near the ISO7816 tag."
        session?.begin()
    }

    // MARK: - NFCTagReaderSessionDelegate

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        //print("ISO7816 session became active")
        print("scanner active")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("ISO7816 session invalidated with error: \(error.localizedDescription)")
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        self.session = nil
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        //print("ISO7816 session detected tags: \(tags.count)")
        print("TAG detected: \(tags.count)")
        if tags.count > 1 {
            session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
            return
        }

        guard let firstTag = tags.first else { return }
        
        session.connect(to: firstTag) { error in
            if let error = error {
                print("Connection error: \(error.localizedDescription)")
                session.alertMessage = "Connection error: \(error.localizedDescription)"
                session.invalidate()
                return
            }

            // Check if it's an ISO7816 tag
            guard case .iso7816(let iso7816Tag) = firstTag else {
                print("Tag is not ISO7816 compliant")
                session.alertMessage = "Tag is not ISO7816 compliant"
                session.invalidate()
                return
            }

            // Try each AID
            self.tryNextAID(iso7816Tag: iso7816Tag, session: session, aidIndex: 0)
        }
    }

    // MARK: - Helper Methods

    private func tryNextAID(iso7816Tag: NFCISO7816Tag, session: NFCTagReaderSession, aidIndex: Int) {
        guard aidIndex < self.iso7816AIDs.count else {
            print("No more AIDs to try")
            session.alertMessage = "No matching AID found"
            session.invalidate()
            return
        }

        let currentAID = self.iso7816AIDs[aidIndex]
        print("Trying AID: \(currentAID)")

        // Convert AID string to Data
        guard let aidData = currentAID.data(using: .ascii) else {
            print("Invalid AID format")
            session.alertMessage = "Invalid AID format"
            session.invalidate()
            return
        }

        
        // Create SELECT APDU command
        let selectCommand = NFCISO7816APDU(
            instructionClass: 0x00,
            instructionCode: 0xA4,
            p1Parameter: 0x04,
            p2Parameter: 0x00,
            data: aidData,
            expectedResponseLength: 1
        )
        print("selected comment \(selectCommand)")
         
        //print("Sending SELECT APDU command for AID: \(currentAID)")
        
        //iso send command
        iso7816Tag.sendCommand(apdu: selectCommand) { responseData, sw1, sw2, error in
            if let error = error {
                print("Error sending command: \(error.localizedDescription)")
                // Try next AID
                self.tryNextAID(iso7816Tag: iso7816Tag, session: session, aidIndex: aidIndex + 1)
                return
            }

            // Check response status
            if sw1 == 0x90 && sw2 == 0x00 {
                print("Successfully selected AID: \(currentAID)")
                print("Response data: \(responseData as NSData)")
                // Process the response data here
                self.processResponseData(responseData)
                session.alertMessage = "Successfully selected AID: \(currentAID)"
                session.invalidate()
            } else {
                print("Failed to select AID: \(currentAID). Status: \(String(format: "%02X%02X", sw1, sw2))")
                // Try next AID
                self.tryNextAID(iso7816Tag: iso7816Tag, session: session, aidIndex: aidIndex + 1)
            }
        }
        
    }

    private func processResponseData(_ data: Data) {
        // Add your response data processing logic here
        print("Processing response data of length: \(data.count)")
        // You can parse the data based on your specific requirements
    }

    // MARK: - Message Handling

    func addMessage(fromUserActivity message: NFCNDEFMessage) {
        DispatchQueue.main.async {
            self.detectedMessages.append(message)
            self.tableView.reloadData()
        }
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detectedMessages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let message = detectedMessages[indexPath.row]
        cell.textLabel?.text = "Message \(indexPath.row + 1)"
        return cell
    }
}
