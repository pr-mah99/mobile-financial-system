<?php
// app/Mail/MoneyTransferNotification.php

namespace App\Mail;

use App\Models\Transaction;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class MoneyTransferNotification extends Mailable
{
    use Queueable, SerializesModels;

    public Transaction $transaction;
    public string $type; // 'sender' or 'recipient'

    /**
     * Create a new message instance.
     */
    public function __construct(Transaction $transaction, string $type)
    {
        $this->transaction = $transaction;
        $this->type = $type;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        $subject = $this->type === 'sender'
            ? 'تأكيد إرسال الأموال - ' . $this->transaction->reference_number
            : 'إشعار استلام الأموال - ' . $this->transaction->reference_number;

        return new Envelope(
            subject: $subject,
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        return new Content(
            view: 'emails.money-transfer-notification',
            with: [
                'transaction' => $this->transaction,
                'type' => $this->type,
                'isSender' => $this->type === 'sender',
                'isRecipient' => $this->type === 'recipient',
            ]
        );
    }

    /**
     * Get the attachments for the message.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
